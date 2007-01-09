From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Jan 2007 08:38:52 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <200701090838.52855@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  How can I get a complete copy of the DCCP source checked out, including 
|  your/Ian's patches?  Where is there something on line that explains the git 
|  process?  Thanks for your/anyone's help.
I found the following tutorial useful:
  http://www.kernel.org/pub/software/scm/git/docs/tutorial.html
In addition, Ian's links are also very helpful - they have helped me in the past. 
In the git sources there are a few summary documents as well, I found Documentation/everyday.txt good

Both my patches on    http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/the_whole_lot.tar.gz
and Ian's patches on  http://wand.net.nz/~iam4/dccp/patches/
are `stacked': if you have the quilt tool then it is best to fork a new git branch and apply
them in order. (If not, one can use for p in `cat series`; do patch -p1 < $p; done).
There is overlap between Ian's and my patch set; I usually copy those patches from the list where
we have finished discussion. 

|  > ( I just found out that there is another
|  >   PROBLEM#1: For the first loss interval (as per [RFC 3448, 6.3.1]), the timestamp
|  >             and sequence number are not stored, only the interval is. )
I just noted that I was wrong here - timestamp and sequence number are stored, but by a
different routine (dccp_li_hist_interval_new) - it would be great if we could perform the
storing of timestamp/sequence number always in the same function (dccp_li_update_li).

|  > 
|  > For all other loss events, timestamp and sequence number are stored. This also holds
|  > for I_0; it could be that the interval is 0 here due to (seq_temp becomes `interval')
|  >    seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_nonloss);
|  > but I am not entirely sure about that. And it is probably safer to encode this
|  > case more explicitly.
|  > 
|  > In any way, this clarification leads to 
|  > PROBLEM#2: Since I_0 always sits at the head of the list, there are at most n=7 
|  >            completed loss interval entries (not 8 as the RFC recommends).
|  
|  I find this difficult to follow, but is there still confusion?  According to 
|  my reading of the patches, and Ian confirmed this, what RFC3448 means by I_0 
|  **is not stored on the list at all**.  The list stores I_1...I_8.  Remember 
|  that I_0 is the incomplete loss interval.
ACK - I_0 is the incomplete loss interval. The way the code is currently organised,
I_0 sits always on top of the list, which is due to:
 * in ccid3_hc_rx_packet_recv(), the call to ccid3_hc_rx_detect_loss() comes first
 * ccid3_hc_rx_detect_loss in turn calls dccp_li_update_li()
 * control then resumes in ccid3_hc_rx_packet_recv()
Hence the detection of a loss event always triggers insertion of the sequence number 
and timestamp at the head of the list. 
With regard to your above comment, we should probably change this so that I_0 is
not stored on top of the list - or adapt the list handling so that I_0 can be distinguished
from I_1 ... I_k (k <= 8).

 
|  > |  Your comments about Ian's patch are also wrong, for the same reason.  I 
|  > |  believe Ian's patch calculates I_tot0 and I_tot1 correctly, although with 
|  > |  swapped names.  Certainly if there is a problem it is not the one you have 
|  > |  identified.
|  > If the above assumption that the interval of I_0 is 0 holds then in Ian's patch
|  > (where I_0' is the interval called `non_loss' in Ian's patch) we have that
|  >  -  I_tot0 is the sum  I_1 * w_1 + ... I_7 * w_7  
|  >  -  I_tot1 is the sum  I_0' * w_0 + I_1 * w_2 +  I_2 * w3 + ... + I_6 * w_7
|  > This can't be right.
|  
|  Your analysis is wrong, I think.  Ian's patch sent 12/27 calculates
|  
|     I_tot0 = I_1 * w_0 + ... + I_8 * w_7
|     I_tot1 = I_0 * w_0 + I_1 * w_1 + ... + I_7 * w_7.
|  
|  Because "i" starts at 0.  The relevant part of the patch.
|  
|    			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
|    			w_tot  += dccp_li_hist_w[i];
|  +			if (i != 7)
|  +				i_tot1 += li_entry->dccplih_interval
|  +				   * dccp_li_hist_w[i + 1];
|  +			if (i = 0) {
|  +				non_loss = dccp_hdr_seq(skb);
|  +				sub48(&non_loss, li_entry->dccplih_seqno);
|  +			}
|  
|  When "i = 0", the loop is examining I_1.  Then i_tot0 += I_1*w[0], and i_tot1 
|  += I_1*w[1], exactly as one would like.  The case "i=7" (that is, I_8) 
|  affects i_tot0 but not i_tot1, exactly as one would like.
I think it is different - that when 'i = 0' then we are looking at I_0. This is confirmed by the statement
		if (i = 0) {
			non_loss = dccp_hdr_seq(skb);
			sub48(&non_loss, li_entry->dccplih_seqno);
		}
which shows how the code uses the last recorded loss sequence number li_entry->dccplih_seqno to compute
the interval length for non_loss = I_0. 
Hence we have here that i_tot0 += I_0' * w[0] and i_tot1 += I_0' * w[1], where I_0' is the interval
stored in li_entry. As per earlier email this could be 0 but I am still not entirely sure it is.
 
In the second iteration of the loop we have 

 i_tot0 += I_1 * w[1]
 i_tot1 += I_1 * w[2]

and in the third we have

 i_tot0 += I_2 * w[2]
 i_tot1 += I_2 * w[3]

but the RFC says

 I_tot0 = I_0 * w[0] + I_1 * w[1] + I_2 * w[2] + I_3 * w[3] + I_4 * w[4] + I_5 * w[5] + I_6 * w[6] + I_7 * w[7]
 I_tot1 = I_1 * w[0] + I_2 * w[1] + I_3 * w[2] + I_4 * w[3] + I_5 * w[4] + I_6 * w[5] + I_7 * w[6] + I_8 * w[7]

which is different from what the above code does. 

So I think what we can take home as `todo' items from this is
 * correct the list handling with regard to I_0 
 * ensure that I_1 ... I_8 all fit in the list
 * compute the interval length I_0 as done for `non_loss' in Ian's patch
 * change the summation loop so that it matches the one in the RFC

I am still trying to compile all this into (yet another :) summary, thanks for your comments.

Gerrit
