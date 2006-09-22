From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 17:57:05 +0000
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <200609221857.05287@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  > I would like to suggest a compromise: retaining an experimental patch which allows
|  > this socket option and can be used for people interested in experimenting with these
|  > ideas, to gain new insights; and to leave the main kernel API as simple as it can
|  > possibly be made.
|  
|  That is exactly what my patch is. The socket option is not required so
|  much of the debate is pointless!
|  
|  You could argue over the correct default for a socket but my patch
|  doesn't alter that.
|  
|  After seeing all the discussion I would still like the patch in.
I fully agree with Ian.
