From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 12:01:02 +0000
Subject: Re: [PATCH 0/8]: Sequence numbers, larger windows revisited, minor cleanups
Message-Id: <200612211201.02804@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612151049.50073@strip-the-willow>
In-Reply-To: <200612151049.50073@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you - but what I actually wanted/needed to know is:

 * OK to ditch the add48/sub48 functions (which take a pointer to u64 and thus are useless on 48:-bit fields)?
 * OK to instead use the following macros instead?
#define add48(seqno, b)     	seqno = (seqno + (b)) & DCCP_MAX_SEQNO
#define sub48(seqno, b) 	add48(seqno, COMPLEMENT48((b)))
#define inc48(seqno)		add48(seqno, 1)

Reasons: 
	1) this kind of sequence arithmetic seems unlikely to be used for main DCCP
           data structures which all use u64 to store sequence numbers (e.g. all places 
           where dccp_inc_seqno is used)
	2) ccid3 has very long names, it makes things simpler to put assignent into the macro
	3) with a function this kind of assignment is not possible, and the operation is actually simple

Gerrit

Quoting Ian McDonald:
|  On 12/19/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > I am not fussy about getting the patches into 2.6.20 at all cost. I am reconsidering
|  > the add48/sub48 and the dccp_inc_seqno functions/macros.
|  >
|  Gerrit,
|  
|  I think leave your code in as it covered more cases than mine and it
|  works - I've been doing quite a bit of testing of CCID3 and I'm happy
|  with your code as per your patch series.
|  
|  Ian
