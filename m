From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 16:53:08 +0000
Subject: Re: [RFC-RESEND] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <200611161653.09002@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611151859.19282@strip-the-willow>
In-Reply-To: <200611151859.19282@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo,

|  Thanks, applied.
many thanks for applying this; it was sooner as expected and I think it would
be good to tidy this up and make it consistent throughout the code. Since I initiated this,
I feel a bit obliged to improve this.

In particular, I have thought about the following scheme which divides warning messages into
two (plus debug) categories

a) GRADE 1: Severe Protocol/Internal Faults
            This includes 
		* violated pre- / postconditions, 
		* illegal states
		* malfunctioning (something is NULL)
   I think these messages should not be rate-limited and, catching up on the discussion,
   should dump the stack after the warning message. 

b) GRADE 2: Plain Misbehaviour
		* out-of-memory messages
		* Request floods
		* protocol violations (wrong message/option format)

To make this consistent, I would like input whether the following is ok with you:

	1) use DCCP_BUG for all Grade 1 type of messages, i.e. it would replace 
		* BUG()
		* WARN_ON() (of course with the appropriate message)
		* all sections using 'printk(KERN_CRIT ... ); dump_stack()'

	2) either keep the LIMIT_NETDEBUG(KERN_WARNING ... ) for Grade 2 or
           put it into a macro which would add the __FUNCTION__ thing to it
 	   
The point is that, if it is done consistently, (1) can later be replaced with the more
conventional BUG() or WARN_ON() once everyone is sure that the code behaves exactly as it shoulds.
For the moment, as Ian has pointed out, bringing the machine to a grinding halt for every little
problem is probably too much of a nuisance (in the same vein, I would really like to suggest the
return of Unload Hack :0).

If you are ok with this basic scheme, I shall set about and tidy things up, otherwise please let
me know what the constraints should be with regard to warning/bug messages.

Best,
Gerrit
