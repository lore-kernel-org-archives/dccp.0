From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Jul 2007 11:46:26 +0000
Subject: Re: [PATCH 3/4]: Unaligned pointer access
Message-Id: <200707021246.26250@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706281510.45724@strip-the-willow>
In-Reply-To: <200706281510.45724@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 6/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [DCCP]: Unaligned pointer access
|  >
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
|  (I don't really understand the alignment stuff but trust you!)
The described exceptions happened on a sparc64 machine (I don't have x86_64).

As far as I know on an i386 you can access unaligned data without performance
penalty, on other machines (such as sparc64), unaligned access is handled by
an exception handler - and this is very expensive.

The get|put_unaligned in include/asm-xxx/unaligned.h avoid triggering the unaligned
exception. 

It is not complicated, a nice summary is in Linux Device Drivers #3, Chapter 11
and examples are in include/asm-generic/unaligned.h
