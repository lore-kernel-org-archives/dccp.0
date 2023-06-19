From: David Howells <dhowells@redhat.com>
Date: Mon, 19 Jun 2023 12:05:27 +0000
Subject: Re: [PATCH net-next v2 17/17] net: Kill MSG_SENDPAGE_NOTLAST
Message-Id: <784658.1687176327@warthog.procyon.org.uk>
List-Id: <dccp.vger.kernel.org>
References: <20230617121146.716077-18-dhowells@redhat.com>
In-Reply-To: <20230617121146.716077-18-dhowells@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:

> Is it intentional to add MSG_MORE here in this patch?
> 
> I do see that patch 3 removes this branch:

Yeah.  I think I may have tcp_bpf a bit wrong with regard to handling
MSG_MORE.

How about the attached version of tcp_bpf_push()?

I wonder if it's save to move the setting of MSG_SENDPAGE_NOPOLICY out of the
loop as I've done here.  The caller holds the socket lock.

Also, I'm not sure whether to take account of apply/apply_bytes when setting
MSG_MORE mid-message, or whether to just go on whether we've reached
sge->length yet.  (I'm not sure exactly how tcp_bpf works).

David
---

static int tcp_bpf_push(struct sock *sk, struct sk_msg *msg, u32 apply_bytes,
			int flags, bool uncharge)
{
	bool apply = apply_bytes;
	struct scatterlist *sge;
	struct page *page;
	int size, ret = 0;
	u32 off;

	flags |= MSG_SPLICE_PAGES;
	if (tls_sw_has_ctx_tx(sk))
		msghdr.msg_flags |= MSG_SENDPAGE_NOPOLICY;

	while (1) {
		struct msghdr msghdr = {};
		struct bio_vec bvec;

		sge = sk_msg_elem(msg, msg->sg.start);
		size = (apply && apply_bytes < sge->length) ?
			apply_bytes : sge->length;
		off  = sge->offset;
		page = sg_page(sge);

		tcp_rate_check_app_limited(sk);
retry:
		msghdr.msg_flags = flags;

		/* Determine if we need to set MSG_MORE. */
		if (!(msghdr.msg_flags & MSG_MORE)) {
			if (apply && size < apply_bytes)
				msghdr.msg_flags |= MSG_MORE;
			else if (!apply && size < sge->length &&
				 msg->sg.start != msg->sg.end)
				msghdr.msg_flags |= MSG_MORE;
		}

		bvec_set_page(&bvec, page, size, off);
		iov_iter_bvec(&msghdr.msg_iter, ITER_SOURCE, &bvec, 1, size);
		ret = tcp_sendmsg_locked(sk, &msghdr, size);
		if (ret <= 0)
			return ret;

		if (apply)
			apply_bytes -= ret;
		msg->sg.size -= ret;
		sge->offset += ret;
		sge->length -= ret;
		if (uncharge)
			sk_mem_uncharge(sk, ret);
		if (ret != size) {
			size -= ret;
			off  += ret;
			goto retry;
		}
		if (!sge->length) {
			put_page(page);
			sk_msg_iter_next(msg, start);
			sg_init_table(sge, 1);
			if (msg->sg.start = msg->sg.end)
				break;
		}
		if (apply && !apply_bytes)
			break;
	}

	return 0;
}
