From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 10:24:14 +0000
Subject: Re: [PATCH 7/10]: Avoid `division by zero' errors
Message-Id: <200611271024.14815@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.56426@strip-the-willow>
In-Reply-To: <200611241619.56426@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID 3]: Avoid `division by zero' errors
|  >
|  > Several places of the code divide by the current RTT value. A division-by-zero
|  > error results if this value is 0.
|  > To protect against this,
|  >    * DCCP_BUG_ON conditions are added throughout the tx code;
|  
|  I can't remember what the definition of DCCP_BUG_ON was in the end.
|  
|  If it does follow the BUG path then I would like this changed to
|  DCCP_WARN... so that we don't kill the machine.

DCCP_BUG_ON is exactly for this purpose since we discussed it earlier:

#define DCCP_BUG(a...)       do { DCCP_CRIT("BUG: " a); dump_stack(); } while(0)
#define DCCP_BUG_ON(cond)    do { if (unlikely((cond) != 0))               \
                                     DCCP_BUG("\"%s\" holds (exception!)", \
                                              __stringify(cond));          \
                             } while (0)

The most important thing is that in places where DCCP_BUG(_ON) is called, it means
that something _internal_ is going wrong; and this should be fixed. Once it is fixed,
and we are sure it is unlikely to occur, we can simply replace

	DCCP_BUG()      with    BUG()     and
	DCCP_BUG_ON()   with    BUG_ON()

DCCP_WARN() on the other side is used for _external_ conditions (outside our control)]
going wrong, hence it is rate-limited, as suggested by Arnaldo.
