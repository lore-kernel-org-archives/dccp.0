From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Tue, 05 Jun 2007 16:27:37 +0000
Subject: DCCP performances
Message-Id: <fca78b970706050927k53a1107fr680a17a4d48b99e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi again,

Here is a description of another point I'd like to report. It's
obvious if you think on it, but it's not if you don't.
I ran some tests the last couple of days, and I was surprise by the
bitrate iperf gave   me : at about 50kbits/sec... and I didn't
understand why since last week. The problem was the debug messages
printing.

It takes lots of time to write in a file, and I enabled debug messages options.
So, I can let you imagine my logs... 3Go at the end of the day...
I disabled these options (in /etc/modprobe.d/networks)... the bitrate
given by iperf is now about 2.3Mbits/sec.

And I noticed the same "problem" using dccp_probe module only. It
slows down the traffic at about 1.7Mbits/sec. It prints out less
information so it makes sense to have a better birate than with debug
messages enabled.

So the point is all these values are wrong since their printing affect
rate, RTT, loss, .... calculation.

rgds,
Patrick.
