From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 10:43:01 +0000
Subject: Re: [PATCH 3/6]: Migrate to new naming scheme, using macro to declare cache
Message-Id: <200706171143.01292@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706111341.49697@strip-the-willow>
In-Reply-To: <200706111341.49697@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 6/17/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > Ian McDonald wrote:
|  > |  > [TFRC]: Migrate to new naming scheme, using macro to declare cache
|  > |  >
|  > |  I agree totally with the intent. I reworked li_hist as well but
|  > |  Arnaldo decided to do in a better way and I think he'll want the same
|  > |  for this also.
|  > Is this an Ack?
|  
|  Not yet - it's saying look at his patch and see if you want to match
|  his style...
Difficult to see what is meant. I think that my set mirrors in a way what Arnaldo
does in the spirit, but not in detail. Since in the end the approach is different.
But the principles are similar: 
 * also use explicit allocation/deallocation routines 
 * also put the slab allocation into the module, as Arnaldos patch 
 * effectively the same functions are removed in my changeset
 * as discussed earlier, modularity of calc_first_li is achieved by using a function pointer.
 
=> wonder whether I should add `__read_mostly' to the slab declaration, but that is 
    a smaller issue. I will think about this.

The main difference is that in my changeset further functionality is implemented which
intersects with the work Arnaldo has been doing. 

|  >
|  > |  See his patch (which is in Dave M's tree now) at:
|  > |  http://www.mail-archive.com/dccp@vger.kernel.org/msg01879.html
|  > |
