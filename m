From: Alessandro Ferraiuolo <aferraiuolo@gmail.com>
Date: Tue, 20 May 2008 13:55:16 +0000
Subject: DCCP kernel crash during feature negotiation
Message-Id: <4832D844.8010205@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,
we are working with DCCP for a project at the University of Naples 
"Federico II"
and we observed an unusual behavior of the kernel used in these tests.
 
Test-bed:         -Debian with Kernel 2.6.25-rc8

(test tree from "git://eden-feed.erg.abdn.ac.uk/dccp_exp my_dccp")

                  -2 Pc connected back-to-back
                  -D-ITG used as traffic generator
 
We use the default kernel configuration, i.e. we issued no sysctl 
commands regarding dccp.
However, D-ITG allows to specify the ccid to be used on the command line.
Our code is essentially this:
 
struct dccp_so_feat dsf;
dsf.dccpsf_feat = 1;
dsf.dccpsf_val = &required_ccid;
dsf.dccpsf_len = sizeof(ccid);
setsockopt(sock,SOL_DCCP, 3, &dsf, sizeof(dsf))
setsockopt(sock,SOL_DCCP, 4, &dsf, sizeof(dsf))
 
... where required_ccid is specified by the user on the command line.
 
Loading only the module named "dccp" (with "modprobe dccp"), when we use
ccid2, we have no problems. The module dccp_ccid2  is loaded automatically
and everything goes all right.
 
When we try to use ccid3, unlike ccid2, the module dccp_ccid3 is not
loaded. The two pc start communicating by using ccid2

and, after few packets, they try to change it through the options
"CHANGE L" and "CHANGE R". From this moment they enter into a loop
in which each of them sends to the other one a CHANGE_L, a CHANGE_R, a
CONFIRM_L, and a CONFIRM_R.
They send these options inside ack packets and, after few seconds, the
flow of ACKs becomes so fast that the kernel freezes and the system crashes.
 
You can find a trace of data-flow sniffed by Wireshark at the following 
link:


http://wpage.unina.it/a.botta/dccp_ccid3_error 
<http://wpage.unina.it/a.botta/dccp_ccid3_error>

In this trace you can observe that after the normal start of
communication with some TCP packet, Sender and
Receiver start to try to change the options in the previously explained
never ending loop.
 
We know that not loading the module and trying to use it is not the
right procedure. However, we do not believe this behavior is correct.

Do you think that D-ITG has to cope with this problem or is demanded to
the kernel ?
 
Thank you for your help and bye.
 
Alessandro
 
P.S. In the mainline kernel (2.6.22 version) this does not happen.
If we do not load the modules, the communication never starts.

