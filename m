From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 20 Jul 2007 20:40:05 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707201340k7397dad6ua0ba3ec5980056ab@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> My understanding that it is a good thing to track netdev, but it will make debugging
> a bit more laborious. It is an acknowledged issue that there are still many bugs
> outstanding in 2.6.21/22, and I have been experiencing many crashes during the last
> month which vanished mysteriously a couple of days/revisions later.
>
I would suggest tracking from about rc3 or rc4 on each release and
then that way you have a slightly more stable kernel and things are
ready for merge at the next window if we are ready and Arnaldo is
ready.

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
