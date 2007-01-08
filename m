From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Mon, 08 Jan 2007 16:55:21 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit
Message-Id: <45A27779.7000405@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

First I would like to send a NEWBIE REQUEST.

How can I get a complete copy of the DCCP source checked out, including 
your/Ian's patches?  Where is there something on line that explains the git 
process?  Thanks for your/anyone's help.

Now:

> |  RFC 3448 says that I_0 "represents the number of packets received since the 
> |  last loss event".  (Section 5.5)  In the Linux implementation, this number is 
> |  NOT stored in the li_entry list.  It must be calculated.  This is what Ian's 
> |  nonloss manipulations do.
> |  
> |  There are a number of errors in your discussion.  You claim that I_0 is the 
> |  "most recent loss interval", and that it is stored in the li_entry structures. 
> |    But what RFC 3448 means by I_0 is not stored in the Linux DCCP 
> |  implementation's li_entry structures.  Your comments under "This is the 
> |  crucial point" do not seem to realize this.
> There is truth in this, but I need to put it in relation to how the list is handled. 
> What I stated below in "This is the crucial point" is that the highest received seqno
> and CCVal are always stored at the head of the list. 
> 
> ( I just found out that there is another
>   PROBLEM#1: For the first loss interval (as per [RFC 3448, 6.3.1]), the timestamp
>             and sequence number are not stored, only the interval is. )
> 
> For all other loss events, timestamp and sequence number are stored. This also holds
> for I_0; it could be that the interval is 0 here due to (seq_temp becomes `interval')
>    seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_nonloss);
> but I am not entirely sure about that. And it is probably safer to encode this
> case more explicitly.
> 
> In any way, this clarification leads to 
> PROBLEM#2: Since I_0 always sits at the head of the list, there are at most n=7 
>            completed loss interval entries (not 8 as the RFC recommends).

I find this difficult to follow, but is there still confusion?  According to 
my reading of the patches, and Ian confirmed this, what RFC3448 means by I_0 
**is not stored on the list at all**.  The list stores I_1...I_8.  Remember 
that I_0 is the incomplete loss interval.

> |  Your comments about Ian's patch are also wrong, for the same reason.  I 
> |  believe Ian's patch calculates I_tot0 and I_tot1 correctly, although with 
> |  swapped names.  Certainly if there is a problem it is not the one you have 
> |  identified.
> If the above assumption that the interval of I_0 is 0 holds then in Ian's patch
> (where I_0' is the interval called `non_loss' in Ian's patch) we have that
>  -  I_tot0 is the sum  I_1 * w_1 + ... I_7 * w_7  
>  -  I_tot1 is the sum  I_0' * w_0 + I_1 * w_2 +  I_2 * w3 + ... + I_6 * w_7
> This can't be right.

Your analysis is wrong, I think.  Ian's patch sent 12/27 calculates

   I_tot0 = I_1 * w_0 + ... + I_8 * w_7
   I_tot1 = I_0 * w_0 + I_1 * w_1 + ... + I_7 * w_7.

Because "i" starts at 0.  The relevant part of the patch.

  			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
  			w_tot  += dccp_li_hist_w[i];
+			if (i != 7)
+				i_tot1 += li_entry->dccplih_interval
+				   * dccp_li_hist_w[i + 1];
+			if (i = 0) {
+				non_loss = dccp_hdr_seq(skb);
+				sub48(&non_loss, li_entry->dccplih_seqno);
+			}

When "i = 0", the loop is examining I_1.  Then i_tot0 += I_1*w[0], and i_tot1 
+= I_1*w[1], exactly as one would like.  The case "i=7" (that is, I_8) 
affects i_tot0 but not i_tot1, exactly as one would like.

Eddie
