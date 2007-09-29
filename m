From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Sat, 29 Sep 2007 11:52:34 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709291452.34807.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Le Friday 28 September 2007 18:40:04 Gerrit Renker, vous avez écrit :
> |  Other than that, and apart from pending DCCP service code support I am
> | happy to announce that the official VLC development tree now support DCCP
> | out-of-the-box with RTP.
>
> Great! That means that the old hack (which you commented on earlier) on
>     http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#VLC_Patch
> can go in favour of something properly integrated with the VLC code. Many
> thanks for looking after this.
>
> I am assuming that this relies on the non-blocking connect you described?
> If yes, I shall make sure that the patch to do this is tidied up and submit
> it early next week - this needs some more thought.

Indeed without the patch, VLC will fail to detect "refused" DCCP connection as 
failed.

-- 
Rémi Denis-Courmont
http://www.remlab.net/
