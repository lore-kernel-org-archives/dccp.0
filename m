From: h.balan@iu-bremen.de
Date: Mon, 23 Jan 2006 18:39:34 +0000
Subject: loss detection and tfrc rate
Message-Id: <64065.84.56.242.24.1138041574.squirrel@mail2web.iu-bremen.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


I was using DCCP over a very lossy setup (more than 10% losses in each
direction) and I could not get the kernel to stop in the detect_loss()
function (using UML and setting breakpoints). I inserted a printk() in
dccp_li_hist_calc_i_mean() which should be called by all TFRC rate
calculations, but, according to the logs, this function is not called
either.
I would appreciate if someone could check this again, since there
are people on the list much more familiar with the implementation.

My second question regards the loss intervals used by TFRC. In one of the
defining documents it is mentioned that a loss interval should be at least
one measured RTT long, however I could not see where this is implemented
in the source code. Could someone help me here?

Regards,
Vlad Balan

