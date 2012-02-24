From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Feb 2012 16:12:07 +0000
Subject: Re: RTT info gets stuck
Message-Id: <20120224161207.GA3725@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAASEuDw1Tq3kznzWEzzD+W-=U-m+C2NBHRLp76zkVuONspMhVQ@mail.gmail.com>
In-Reply-To: <CAASEuDw1Tq3kznzWEzzD+W-=U-m+C2NBHRLp76zkVuONspMhVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Victor,
|    While logging the values of the dccp statistics (the fields "x_recv",
|    "rtt" and "p" of the structure tfrc_rx_info) we have noticed that the
|    values of RTT get stuck at some point and they never change again.
|    Is that normal?
| 
Without further information, it is difficult to say what is going on. I would personally
run wireshark (ideally on both sides of the connection), to see if packets get stuck, i.e.
no more traffic. 

A second point is -- do you use the test tree? If problems are experienced with the 
mainline kernel, the default suggestion is to see if the same problem persists with
the test tree. It is much more difficult to backport things to mainline, slowly the
test tree is being submitted, in chunks, for mainline.

Please do feel free to post again once there is more detailed information on the problem.

Gerrit
