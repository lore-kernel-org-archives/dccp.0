From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Jan 2007 09:37:26 +0000
Subject: Re: [PATCH 4/7]: Provide function for RTT sampling
Message-Id: <200701240937.26648@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701231541.01730@strip-the-willow>
In-Reply-To: <200701231541.01730@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Is 100 microseconds a bit high perhaps? I'm seeing about 250
|  microseconds on a 100 Mbits LAN and therefore presumably on a 10 Gbits
|  LAN it could be as low as 2.5 microseconds??
This is correct, but these are not speeds that CCID 3 can handle. From my
calculations, the maximum speed is about 12 kilobits/second: the best possible
t_gran is 1 millisecond; whenever t_ipi < t_gran, then the speed of sending
packets is no longer controlled by the packet scheduling.
