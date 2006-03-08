From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 08 Mar 2006 19:18:00 +0000
Subject: Re: Report: feat negot state
Message-Id: <28029075-7E49-47AD-BF8F-79B3AC0F5F35@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hey Andrea!

Just a couple things:

On Mar 8, 2006, at 11:01 AM, Andrea Bittau wrote:
>
>> It's not that bad.  (1) All feature negotiation options are  
>> limited to 252
>> bytes of feature value at most.  (2) All current SP features are  
>> one-byte
>> valued.  So you can do this.
>
> yea, but I was thinking if you chain many change X in the same  
> packet.  I'm not
> sure that's legal.  But anyway, an implementation may process  
> options from the
> tail of the packet to front, and discard any previously seen  
> feature negos for
> the same option.

(1) Implementations MUST process options from front to back.   
"Options MUST be processed sequentially, starting at the first option  
in the packet header."

(2) "A packet MAY contain more than one feature negotiation option,  
possibly including two options that refer to the same feature; as  
usual, the options are processed sequentially."

> yea, in fact i got "scared" when I wrote the multi-byte patch.  the:
> if (c = s)
> became a:
> if (memcmp(c, s, len) = 0)

Yep :)

Eddie

