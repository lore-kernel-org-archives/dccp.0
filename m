From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 01 Jun 2022 09:58:12 +0000
Subject: Re: [PATCH net-next v1 1/2] net: Update bhash2 when socket's rcv saddr changes
Message-Id: <5e8ccf5fb949fb8bef822f379f7a410ccd6b6f41.camel@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <CANn89i+pg8guF+XeOngSMa4vUD81g=u-pCBpi0Yp2WB9PQZvdg@mail.gmail.com>
In-Reply-To: <CANn89i+pg8guF+XeOngSMa4vUD81g=u-pCBpi0Yp2WB9PQZvdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

On Tue, 2022-05-31 at 15:04 -0700, Eric Dumazet wrote:
> On Tue, May 24, 2022 at 4:20 PM Joanne Koong <joannelkoong@gmail.com> wrote:
> > 
> > Commit d5a42de8bdbe ("net: Add a second bind table hashed by port and
> > address") added a second bind table, bhash2, that hashes by a socket's port
> > and rcv address.
> > 
> > However, there are two cases where the socket's rcv saddr can change
> > after it has been binded:
> > 
> > 1) The case where there is a bind() call on "::" (IPADDR_ANY) and then
> > a connect() call. The kernel will assign the socket an address when it
> > handles the connect()
> > 
> > 2) In inet_sk_reselect_saddr(), which is called when rerouting fails
> > when rebuilding the sk header (invoked by inet_sk_rebuild_header)
> > 
> > In these two cases, we need to update the bhash2 table by removing the
> > entry for the old address, and adding a new entry reflecting the updated
> > address.
> > 
> > Reported-by: syzbot+015d756bbd1f8b5c8f09@syzkaller.appspotmail.com
> > Fixes: d5a42de8bdbe ("net: Add a second bind table hashed by port and address")
> > Signed-off-by: Joanne Koong <joannelkoong@gmail.com>
> > ---
> 
> Reviewed-by: Eric Dumazet <edumzet@google.com>
> 
Apparently this patch (and 2/2) did not reach the ML nor patchwork (let
alone my inbox ;). I've no idea on the root cause, sorry.

@Joanne: could you please re-post the series? (you can retain Eric's
review tag)

Thanks!

Paolo
