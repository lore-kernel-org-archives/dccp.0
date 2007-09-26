From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:27:24 +0000
Subject: Re: tcpdump broken wrt CsCov & CsVal parsing?
Message-Id: <20070926182724.GA10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20070922144111.GE10051@ghostprotocols.net>
In-Reply-To: <20070922144111.GE10051@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 25, 2007 at 09:08:29AM +0100, Gerrit Renker escreveu:
> |  On 9/23/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> |  > Trying to rebuild a proper test setup, so far using just loopback for
> |  > simple tests I noticed this problem:
> |  >
> |  > Who was the last person to touch the DCCP support code in tcpdump? Care
> |  > to take a look?
> |  >
> |  > - Arnaldo
> |  
> |  I'm pretty sure that would be me :-(
> |  
> |  I'll take a look but it won't be very soon.
> |  
> ... and me too :) I know this problem - CsCov and CCVal were swapped in the
> header file. As far as I recall the maintainer had checked an update in last
> year.
> 
> You didn't say which version of tcpdump you were using, I checked locally:
>  * tcpdump 3.9.5 as Debian package with libpcap 0.9.5 has this swap-problem 
>  * tcpdump 3.9.5 built from tcpdump source, with libpcap 0.9.4 works correct
> 
> Can you try tcpdump from source please and check if the problem persists?

Excellent data point, I should know better and try with upstream before
complaining. Ah, and also provide the tcpdump version:

[root@tonchinha ~]# rpm -q tcpdump
tcpdump-3.9.7-3.fc8

I'll check upstream now.

- Arnaldo
