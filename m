From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 08:54:32 +0000
Subject: Re: 2.6.19-rcX vs 2.6.20
Message-Id: <200610240954.32895@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610240848.47708@strip-the-willow>
In-Reply-To: <200610240848.47708@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian  

Thanks for the tip, I know your web repository and will certainly look at
stgit (I am doing something like that at the moment). 

|  I would like to see bug fixes in 2.6.19 too if they are obvious fixes
|  e.g. the one I sent today. I won't get into the debate about other
|  cosmetic ones....
The problem is not in cosmetics. Each new patch potentially changes offsets
and contexts of outstanding ones (cosmetic or not), so doing `x' now will
imply having to re-do `y' at a later time, whereas my idea was to to both `x' and
`y' at one time.

To make a start, I will submit the batch of what I have (but explicitly not for 2.6.19)
so that hopefully the patch situation can be a little clarified.

Gerrit
