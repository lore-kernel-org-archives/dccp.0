From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 19 Jun 2008 13:38:18 +0000
Subject: Re: QUESTION : Feature length about the non-negotiable feature
Message-Id: <20080619133818.GB15815@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48579530.4010807@cn.fujitsu.com>
In-Reply-To: <48579530.4010807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> The RFC doesn't really require that you reset the connection just if the  
> length is strange.  Accepting valid values expressed in an strange 
> length, but generating only the required lengths, seems like a good 
> application of the TCP robustness principle ("be conservative in what you 
> do,  be liberal in what you accept from others", explicitly in RFC4340 
> 3.6).
>
Thank you for the input. I had written this with possible forthcoming
inter-op tests in mind. What Wei is doing is in principle also an
inter-op test, with the difference that it uses and automated test stack.

> The discussion on whether Sequence Window should be variable-length begins here:
>
> http://www.ietf.org/mail-archive/web/dccp/current/msg01257.html
> search for "MW5: Section 7.5.2, second paragraph"
>
> The two followups have a bit more.
>
> Magnus Westerlund was one of the IETF's expert reviewers for DCCP; his 
> opinion carried some weight.  Probably I folded too early (I thought the 
> extra "complexity" of a variable-length option wouldn't matter, and the 
> option might occur frequently).
>
There are several arguments which raise questions:

 (1) Making it variable-length increases code complexity
     I think this is not very relevant. The reason is that any option
     also needs to be converted into network-byte order (3.1). When the
     quantities are not 16 or 32 bit, the htons/htonl functions can not
     be used. Arnaldo has written a very clever function dccp_encode_value_var()
     which does both the byte-order conversion and the variable-length copy
     in one swoop. So there is little overhead in making it variable-lengh.
     And for the receiver code the case is similar.

 (2) This option occurs infrequently
     Agree with the above point: NN options are exchanged during the
     established phase and so it depends how frequently they appear.
     In any case they are retransmitted until acknowledged, which is
     one point that increases the frequency.
     If there is a path change or the application increases/decreases
     the sending rate then Sequence Window also needs to be updated,
     hence "occurs infrequently" is not always true.
     It is costly for the loss detection and the Ack Vector length to
     get out of synch, so it seems better to update the Sequence Window
     frequently (i.e. when it changes) rather than risking a "Step 6
     failed" (8.5).

 (3) Header compression
     This did not occur in the discussion but someone mentioned a
     header compression argument as a possible cause for keeping the
     option fixed length. The gain for header compression seems low,
     since Change options are only sent if one endpoint leaves the STABLE
     state (6.6.2) and thus the value of subsequent Change options on
     the same path will always have different values.


> One solution might be a "dccp_pedantic" sysctl, defaulting to 0, where 
> Linux DCCP is guaranteed to be RFC compliant only if "dccp_pedantic" is 
> 1.  (And Sequence Window is variable-length if "dccp_pedantic" is 0.)
I think this refers to the length of outgoing options? In any event,
if people wanted to test different behaviours, it could be made a
Kconfig menu option.

Gerrit
