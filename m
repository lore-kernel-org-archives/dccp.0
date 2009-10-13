From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 13 Oct 2009 17:19:46 +0000
Subject: [PATCH 0/4] Adds implementation of TFRC-SP  sender side into the
Message-Id: <4AD4B6B2.1020502@embedded.ufcg.edu.br>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These patches adds implementation of TFRC-SP at the sender side, and are targeted at the DCCP branch.



Patch #1: Adds random ect generation to tfrc-sp sender side
Patch #2: Implement function that allows to keep track of packets sent in last 2 rtt
Patch #3: Implement dropped packets option
Patch #4: Implement loss intervals option


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
Quidquid latine dictum sit, altum viditur.



