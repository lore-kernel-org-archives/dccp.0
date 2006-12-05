From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 05 Dec 2006 19:52:09 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Message-Id: <5640c7e00612051152o42a347b8o404187d4f4970c38@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > I think it would be good for Arnaldo or another person to sign off on 5, 6
> > and 7 after a bit more of a look. These fix up packet size setting for
> > CCID3 and also change them to work on half connections as you may have
> > different packet sizes for each. I've tested myself thoroughly but others
> > might have an opinion on the style of these. These three patches need to be
> > applied in order.
> >
> Please don't merge patches 5-7 now as per other threads going on.
> These aren't needed I believe. I will still verify that is the case
> but can't yet do that.

I'm now dropping this series of patches (5-7) which provided setting
packet size s for a number of reasons:
- bit rot has set in
- Gerrit's moving average code has been put in
- altering packet size makes no difference to packet rate (see
http://wand.net.nz/~perry/max_download.php ) at present
- probably not tidied up before next merge window closes

I suspect the only time it would make a difference really is if we are
fragmenting packets. Given our implementation doesn't support this
it's no point implementing this.

I will keep a copy (that doesn't apply to current tree) around in case
we need it in the future.

Regards,

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
