From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 09:34:21 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <20080310093421.GA7855@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Just to inform:
| 
| sysctl -w net.dccp.default.send_ackvec=1
| error: "net.dccp.default.send_ackvec" is an unknown key
| 
| I remember that you removed this option in the kernel. In this case I
| will update the DCCP wiki, ok?
| 
This option switches sending Ack Vectors on/off. It was removed since CCID-2
will not work without Ack Vectors, and in CCID-3 Ack Vectors are just ignored.

In the mainline kernel this option is still needed since there is no other way
of enabling Ack Vectors; the test tree enables/disabled according to the CCID.

In the mainline kernel Ack Vectors are by default on (due to
#define DCCPF_INITIAL_SEND_ACK_VECTOR  1), so this will not hurt CCID-2.

Thanks for updating 
http://www.linux-foundation.org/en/Net:DCCP#Choosing_and_initialising_your_CCID
