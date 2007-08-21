From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 19:11:49 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <200708212011.49118@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Yes, this is my case and yesterday I used linus-git with your dccp
|  code and everything worked fine. Today I pulled from your git tree and
|  also worked, but my laptop froze to times and I need to reboot it, I
|  don't now why!
|
I think I know ... I had the same problems - three computers with e100 cards
just froze. It really seems that this is due to a half-finished merge window.

What I have done for the moment is - created a dummy patch which collects
all patches sent by Arnaldo, and put this as first patch into the tree; and rebased
everything onto davem-2.6 (which works fine, tested on 5 different computers).

I'll leave that until the 2.6.24 tree becomes a bit better, so that the code at least
works. Anything else - just let us know.

Gerrit
  
