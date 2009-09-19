From: gerrit@erg.abdn.ac.uk
Date: Sat, 19 Sep 2009 12:23:28 +0000
Subject: Re: [PATCH 3/5] Implement TFRC-SP calc of mean length of loss
Message-Id: <5002.72.11.80.242.1253363008.squirrel@72.11.80.242>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
In-Reply-To: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

>> However, this computation is done in the wrong place: here it is already
>> too
>> late. The N/K in RFC 4828 refers to entering each individual interval
>> I_0, so
>> the division (and the check whether this is a "short" interval) needs to
>> be
>> done when adding the interval, in tfrc_sp_lh_interval_add(). (There also
>> exists
>> a special rule for the open interval I_0, see RFC 5348, 5.3.)
>>
>
>
> Oh, all right. I understood it was wrong. I thought that the loss
> interval needed to be less than 2 rtt old
> but the correct is that it needs to be less than 2 rtt long, right?
>
I think we need to continue this in the other thread: if there is agreement
to keep the CCID-4 implementation receiver-based (i.e. the receiver computes
the Loss Event Rate), then the struct can be extended to record also the
number of lost packets. Depending on whether CCID-3 (TFRC) or CCID-4
(TFRC-SP) is in use, it would then use the division.


>> A second problem is a divide-by-zero condition encoded in the above: if
>> i_i < losses, the result is 0, if all intervals are 0 then I_mean =3D 0,
>> and
>> thus p =3D 1/I_mean triggers a panic. In all other cases, the integer
>> arithmetic
>> has the effect of floor(N/K), i.e. it decreases the interval length.
>>
>> A way out (which does not fix the truncation problem) is to round up:
>>
>> =A0 =A0 =A0 =A0if (losses > 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i_i =3D DIV_ROUND_UP(i_i, losses);
>>
>> In fact, we have to do this, to avoid the divide-by-zero condition.
>
>
> When the loss count (losses) could be greater than loss interval length
> (i_i)?
Excellent point, you are fully right, it is in the spec. (RFC 5622,8.7):

 By definition, this  number MUST NOT exceed the corresponding loss
 interval's Loss Length.

To be on the safe side, I think it would be good to catch the case when
this rule is violated, e.g.
   WARN_ON(losses > i_i);
   if (losses < i_i)
      // some smart solution taking care of the truncation problem


