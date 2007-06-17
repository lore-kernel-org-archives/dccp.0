From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 10:12:54 +0000
Subject: Re: [PATCH 3/6]: Migrate to new naming scheme, using macro to declare cache
Message-Id: <200706171112.54827@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706111341.49697@strip-the-willow>
In-Reply-To: <200706111341.49697@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  > [TFRC]: Migrate to new naming scheme, using macro to declare cache
|  >
|  I agree totally with the intent. I reworked li_hist as well but
|  Arnaldo decided to do in a better way and I think he'll want the same
|  for this also.
Is this an Ack?
  
|  See his patch (which is in Dave M's tree now) at:
|  http://www.mail-archive.com/dccp@vger.kernel.org/msg01879.html
|  
|  I also suspect his patch will stop yours applying.
|  
Yes that's right - I worked out the intersection of recent changes to the
patches submitted so far, and above patch was part of it. Will send
that later.
