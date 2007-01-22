From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 22 Jan 2007 04:08:43 +0000
Subject: [PATCH 0/3] Various DCCP patches
Message-Id: <200701221708.45792.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

OK. Here goes. Been working away today on fixing things up.

First patch is a resend of recalc_loss stuff. I'll trawl through the archives
again later but this one works for me.

Second patch is an implementation of calculating rtt from request/response
handshake.

Third patch is a reworking of packet timing because of above. It's actually
become simpler now because of this.

These patches apply in the order listed at:
http://wand.net.nz/~iam4/dccp/patches/

Where there is an alphanumeric prefix I agree totally with Gerrit. Where I omit
one of his or add one of my own we are not yet in agreement.

Experimental patches are at the end. The only one of note is 
fix_calc_first_li. This fixes some problems in the code. I think it is correct but
want to test some more. It is better than existing code already though.

Ian
