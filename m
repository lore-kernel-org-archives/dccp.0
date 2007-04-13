From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 13 Apr 2007 17:38:58 +0000
Subject: Re: [PATCH-UPDATE]: Changes after retracting timestamping patches
Message-Id: <39e6f6c70704131038g1da7c3e6m5b88a86375e8cf2b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704131825.14989@strip-the-willow>
In-Reply-To: <200704131825.14989@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Following the earlier discussions of patches, here is the update
> after removing the skb_get_timestamp() patches.

OK, starting with the first, how can it be that it honours the initial
exchange if the timestamp is taken now not from the skb timestamp but
at that point in time? I.e. from a quick reading the comment doesn't
make sense anymore, as we're not getting the timestamp taken at packet
arrival, as dccp_timestamp just does a do_gettimeofday.

I think we should take the timestamp at dccp_v[46]_rcv time, into the
skb, that won't be  as precise as
skb_get_timestamp+net_enable_timestamp, but at least will eliminate
the time the packet sits in the backlog (if it sits at all), no?

- Arnaldo
