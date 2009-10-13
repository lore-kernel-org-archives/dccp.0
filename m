From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:26:57 +0000
Subject: Doubt in implementations of mean loss interval at sender side
Message-Id: <4AD4B861.7040107@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

  Hi folks, 
In the  patch #3 of the sender patches series, the algorithm that does
the calc of the mean loss interval suffers with the same problem that
Gerrit pointed at the receiver patches.
It considers if an interval is 2 RTT old, instead of 2 RTT long. But I
sent this code in this state anyway, because I want to ask how to solve
this problem.
I imagined that would be possible to check the loss interval length
upon receiving the feedback from the receiver that contains new loss
intervals option, and to compare this with previous loss intervals info
received.
With this correction I would be able to return the tx history back to
it's normal behavior, instead of keeping 2 RTT's of packets.
Any help/opinions about this?


Cheers,
Ivo

--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab -
http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center -
http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur








