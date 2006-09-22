From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 22 Sep 2006 02:46:30 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Message-Id: <39e6f6c70609211946g34ea56bbp9eeea01920842901@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609221425.16349.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221425.16349.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/21/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Here is my latest set of patches for DCCP.
>
> If possible I would like these to go into 2.6.19. I have tested against
> 2.6.18rc5 and latest net-2.6.19 git tree of Dave M as well.
>
> Dave - Patches 1 and 2 are trivial and just introducing constants and using
> them. Patch 4 is shifting some code into a header. If patch 3 could be
> merged also that would be great - it is just about the same as Stephen
> Hemminger's TCP Probe code but instead for DCCP. Patch 3 depends on patch 1.
>
> I think it would be good for Arnaldo or another person to sign off on 5, 6
> and 7 after a bit more of a look. These fix up packet size setting for
> CCID3 and also change them to work on half connections as you may have
> different packet sizes for each. I've tested myself thoroughly but others
> might have an opinion on the style of these. These three patches need to be
> applied in order.

Everything seems fine, I'll merge them early tomorrow, do some testing
and push to DaveM,

Thanks,

- Arnaldo
