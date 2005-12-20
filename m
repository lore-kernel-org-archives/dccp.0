From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 20 Dec 2005 14:11:13 +0000
Subject: Re: Discussion of ECN API?
Message-Id: <39e6f6c70512200611n2843fd06u651581db5fbad80e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200512192127.jBJLRou27403@observ.crd.ge.COM>
In-Reply-To: <200512192127.jBJLRou27403@observ.crd.ge.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I'm not aware of any, at the same time I think DCCP should at least
expose the info on ack vectors,so the question is: is the information
available on ack vectors enough for you (the app writers?)?

- Arnaldo

On 12/19/05, Bruce Barnett <dccp@grymoire.com> wrote:
>
> I've been involved with the application perspective of DCCP
> programming, or rather - application programming aware of congestion,
> and I was wondering if there exists any API for other transport
> protocols that make congestion information available to the
> application?  In particular, is there any existing API to extract the
> ECN information that can be used for a model?  Or if it is missing, -
> how should it be specified?
>
> One approach is to provide an array of ECN values. But how big would
> this be?  And how would it be packed?
>
> Or one could return a monotonicly increasing count of ECN failures. But
> what is a failure, as there are several kinds.  Some errors should be
> handled by the kernel (Routers that don't support ECN, etc.). Others
> should be of interest to the application (there is congestion in the
> return path).
>
>
> One could also provide a error percentage, but how would this be calculated?
>
>
> Anyone have any ideas or resources I could check?
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
