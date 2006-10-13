From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 13 Oct 2006 23:48:26 +0000
Subject: Re: getaddrinfo - should accept IPPROTO_SCTP no?
Message-Id: <453025CA.70506@hp.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00610131559n4a3ad8c5x66cf4b72deb57868@mail.gmail.com>
In-Reply-To: <5640c7e00610131559n4a3ad8c5x66cf4b72deb57868@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> In all the DCCP code which has similar issues I just do the protocol
> selection on the socket call e.g.
>         case TCP:
>             new_sock = socket(AF_INET,SOCK_STREAM,0);
>             break;
>         case DCCP:
>             new_sock = socket(AF_INET,SOCK_DCCP,IPPROTO_DCCP);
>             break;
>         case UDP:
>             new_sock = socket(AF_INET,SOCK_DGRAM,0);
>             break;
> 
> I'm sure you know all this anyway so apologies in advance for telling
> you something you probably already know!

No worries.

David mentioned that I need to talk to the glibc folks.  I'm still trying to web 
search my way to finding them.  Meanwhile I may do in netperf for this what I do 
for Solaris' arbitrary clearing of the ai_protocol field - kludge around it and 
have netperf emit a warning.

rick jones
