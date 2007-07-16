From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Jul 2007 12:04:08 +0000
Subject: Re: TFRC Faster Restart implementation for Linux DCCP
Message-Id: <200707161304.09079@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
In-Reply-To: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

You didn't write whether you intend this as Linux mainline work.

I am not aware of anyone else working on this so far. However, it reopens a big can
of worms for the CCID3 code in the kernel: much in Faster Restart depends on the 
rfc3448bis changes to computing the sending rate and determining idle/application-limited
times. 
The algorithm keeps changing in each new revision of the rfc3448bis draft, which probably
means that when you've just finished your work, you can start from scratch again.

Thus my suggestion is - if you want to do this community-wise - to do this as part/sub-branch
of the testing tree. There is still a lot of space for further branches, and it is not clear
when all this will stabilise.

Thoughts?

Quoting Ian McDonald:
|  Folks,
|  
|  At the suggestion of my PhD supervisor, I am considering implementing
|  TFRC faster restart for the Linux version of DCCP.
|  
|  From my reading of the correspondence it would seem to me that the
|  testing was done in ns2 and not in the Linux kernel. If this is not
|  correct, or you know of any implementations, can you tell me so I
|  don't reinvent the wheel!
|  
|  Thanks,
|  
|  Ian
