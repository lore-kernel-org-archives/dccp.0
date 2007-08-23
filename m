From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Aug 2007 15:17:21 +0000
Subject: Re: [RFC] DCCP Faster Restart
Message-Id: <200708231617.21338@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00708230143w17881e75va19572e6f7eb3af0@mail.gmail.com>
In-Reply-To: <5640c7e00708230143w17881e75va19572e6f7eb3af0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The patches look good - I'd be happy to put several directly into the test tree.
With regard to the CCID3 code I'd need to check - I wanted to do some regression
testing also, to see that the recent changes have not affected performance.
Application testing with the test tree is so far ok, not fully tested with loss/congestion,
will do.

Quoting Ian McDonald:
|  This patch series implements much of TFRC faster restart as per
|  draft-ietf-dccp-tfrc-faster-restart-03.txt
|  
|  and with changes from:
|  http://www3.ietf.org/proceedings/07jul/slides/dccp-6.pdf
|  
|  Most notably we don't do pings and a few other bits and pieces.
|  
|  I've posted this up at:
|  http://wand.net.nz/~iam4/dccp/patches24/
|  (Ignore patch 7).
|  
|  If anybody is interested they are most welcome to look at.
|  
|  This patch series has been tested but will undergo more work yet
|  before I ask Gerrit to put into tree and before I post as patches to
|  this list:
|  - check that it applies against very latest tree
|  - do some performance testing
|  - rework the socket options code a bit so we can do socket options
|  without parameters (in the meantime pass a dummy parameter rather than
|  null)
|  
|  Ian
