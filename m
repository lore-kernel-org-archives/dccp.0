From: Developer Man <flydevteam@gmail.com>
Date: Fri, 24 Feb 2012 13:08:04 +0000
Subject: RTT info gets stuck
Message-Id: <CAASEuDw1Tq3kznzWEzzD+W-=U-m+C2NBHRLp76zkVuONspMhVQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

While logging the values of the dccp statistics (the fields "x_recv",
"rtt" and "p" of the structure tfrc_rx_info) we have noticed that the
values of RTT get stuck at some point and they never change again.
Is that normal?

This is our set up:
We have 2 machines connected by 3 ppp interfaces. For each interface
we create a dccp connection and we log the rx_info at the receiver.
We log about 5 minutes of connection and we can see that in the first
60 seconds all 3 RTT measurements get stuck (each one at a different
value and in different time)

Thank you!

Victor
