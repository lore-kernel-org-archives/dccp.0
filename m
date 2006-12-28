From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 04:25:36 +0000
Subject: Re: HEADS UP: DCCP debugging
Message-Id: <5640c7e00612272025t5f0462fyd84eff111aea4ace@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20061227171023.GA26840@mandriva.com>
In-Reply-To: <20061227171023.GA26840@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/28/06, Arnaldo Carvalho de Melo <acme@mandriva.com> wrote:
> I've been partying and working on an OSTRA rebirth, this time based on
> my current work on DWARF tools, so to give just a heads up, here is the
> current stage, explanations below:
>
Excellent. Now us mere mortals might be able to use it as I never
quite got ostra working...

> Now to run the client, sending only 5 256 byte sized packets (beware,
> I'm testing over loopback, so listening server, server and client
> sockets will be mixed, that is why the sk is printed):
>
Jeepers - we do a lot for sending and receiving 5 packets....

> And yes, I haven't forgot the DCCP patch backlog :-)
>
Well I've removed one from the backlog and resent...

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
