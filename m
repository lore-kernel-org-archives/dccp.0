From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Mon, 28 Nov 2016 15:05:18 +0000
Subject: Re: [PATCH net] net/dccp: fix use-after-free in dccp_invalid_packet
Message-Id: <20161128150518.GA17913@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Nov 28, 2016 at 06:47:14AM -0800, Eric Dumazet escreveu:
> On Mon, 2016-11-28 at 11:40 -0300, Arnaldo Carvalho de Melo wrote:
> > Em Mon, Nov 28, 2016 at 06:26:49AM -0800, Eric Dumazet escreveu:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > pskb_may_pull() can reallocate skb->head, we need to reload dh pointer
> > > in dccp_invalid_packet() or risk use after free.
> > > 
> > > Bug found by Andrey Konovalov using syzkaller.
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> > 
> > Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> > 
> > I was about to send exactly this patch, and while looking at it I think
> > the patch below needs to go in as well, no? To follow the advice of that
> > Warning line there :-)
> > 
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > 
> > pskb_may_pull() can reallocate skb->head, so we can't access
> > iph->frag_off or risk use after free, save it to a variable and us that
> > later.
> > 
> > Cc: Andrey Konovalov <andreyknvl@google.com>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> > 
> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index 5ddf5cda07f4..9462070561a3 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -1198,6 +1198,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> >  	struct iphdr *iph;
> >  	int proto, tot_len;
> >  	int nhoff;
> > +	u16 frag_off;
> >  	int ihl;
> >  	int id;
> >  
> > @@ -1213,6 +1214,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> >  
> >  	id = ntohs(iph->id);
> >  	proto = iph->protocol;
> > +	frag_off = iph->frag_off;
> >  
> >  	/* Warning: after this point, iph might be no longer valid */
> >  	if (unlikely(!pskb_may_pull(skb, ihl)))
> > @@ -1233,7 +1235,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> >  		fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
> >  
> >  		/* fixed ID is invalid if DF bit is not set */
> > -		if (fixedid && !(iph->frag_off & htons(IP_DF)))
> > +		if (fixedid && !(frag_off & htons(IP_DF)))
> >  			goto out;
> >  	}
> >  
> 
> 
> I do not see why this patch would be needed ?

Where is iph being reloaded after that pskb_may_pull() and thus at line 1236 we
could use after free? The warning at line 1217?

1209         iph = ip_hdr(skb);
1210         ihl = iph->ihl * 4;
1211         if (ihl < sizeof(*iph))
1212                 goto out;
1213 
1214         id = ntohs(iph->id);
1215         proto = iph->protocol;
1216 
1217         /* Warning: after this point, iph might be no longer valid */
1218         if (unlikely(!pskb_may_pull(skb, ihl)))
1219                 goto out;
1220         __skb_pull(skb, ihl);
1221 
1222         encap = SKB_GSO_CB(skb)->encap_level > 0;
1223         if (encap)
1224                 features &= skb->dev->hw_enc_features;
1225         SKB_GSO_CB(skb)->encap_level += ihl;
1226 
1227         skb_reset_transport_header(skb);
1228 
1229         segs = ERR_PTR(-EPROTONOSUPPORT);
1230 
1231         if (!skb->encapsulation || encap) {
1232                 udpfrag = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
1233                 fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
1234 
1235                 /* fixed ID is invalid if DF bit is not set */
1236                 if (fixedid && !(iph->frag_off & htons(IP_DF)))
1237                         goto out;
1238         }

