From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 14 Dec 2006 16:52:18 +0000
Subject: Re: 48-bit sequence number arithmetic
Message-Id: <45818142.4090001@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Subtracting two 32-bit numbers which are 2^31 apart will have the same results.

(int32_t) ((uint32_t) 0 - (uint32_t) 0x80000000) = -0x80000000
(int32_t) ((uint32_t) 0x80000000 - (uint32_t) 0) = -0x80000000

The RFC is not in error and your delta_seqno patch should not be accepted.

As RFC 1982 says:

    Note that there are some pairs of values s1 and s2 for which s1 is
    not equal to s2, but for which s1 is neither greater than, nor less
    than, s2.  An attempt to use these ordering operators on such pairs
    of values produces an undefined result.

    The reason for this is that those pairs of values are such that any
    simple definition that were to define s1 to be less than s2 where
    (s1, s2) is such a pair, would also usually cause s2 to be less than
    s1, when the pair is (s2, s1).  This would mean that the particular
    order selected for a test could cause the result to differ, leading
    to unpredictable implementations.

...

    Thus the problem case is left undefined, implementations are free to
    return either result, or to flag an error, and users must take care
    not to depend on any particular outcome.  Usually this will mean
    avoiding allowing those particular pairs of numbers to co-exist.

Eddie



Gerrit Renker wrote:
> I would like to notify you of an error in RFC 4340.
> 
> In [RFC 4340, sec. 3.1] it is suggested that
>  "It may make sense to store DCCP sequence numbers in the most significant 48 bits
>   of 64-bit integers and set the least significant 16 bits to zero, since this 
>   supports a common technique that implements circular comparison A < B by testing
>   whether (A - B) < 0 using conventional two's-complement arithmetic."
> 
> Unfortunately this does not work.
> 
> Signed 64-bit numbers represent the range -2^63 ... 0 ... 2^63-1. 
> When the difference between two left-shifted 48-bit numbers a and b is +/- 2^63, we can not tell
> whether a is `before' b or b is `before' a: the difference will yield the same negative result -2^63,
> due to the constraints of the data type.
> 
> This case occurs for all 48-bit numbers whose difference amounts to 2^47. Since there are 2^47
> such numbers, this test fails to produce correct results in 2^47 = 140.7375e12 cases.
> 
> The sequence number test based on subtraction works for TCP since signed 32 bit numbers are a native type. 
> For 48 bit, arithmetic operations need to be redeveloped from scratch. It is not sufficient to shift and subtract.
> 
> Regards
> Gerrit Renker
