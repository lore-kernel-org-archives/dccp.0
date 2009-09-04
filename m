From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 04 Sep 2009 12:24:54 +0000
Subject: [PATCH 0/5] Adds implementation of TFRC-SP on DCCP test tree
Message-Id: <1252067094.6172.1.camel@localhost>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011943s656fbadfo95132dc2fba0d73c@mail.gmail.com>
In-Reply-To: <cb00fa210909011943s656fbadfo95132dc2fba0d73c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Due to the problems in the previuos patch pointed by Gerrit Renker, I'm
resending the patches.


These patches adds implementation of TFRC-SP at the receiver side, and
are targeted at the DCCP branch



Patch #1: First Patch on TFRC-SP. Copy base files from TFRC
Patch #2: Implement loss counting on TFRC-SP receiver
Patch #3: Implement TFRC-SP calc of mean length of loss intervals
accordingly to section 3 of RFC 4828
Patch #4: Adds options DROPPED PACKETS and LOSS INTERVALS to receiver
Patch #5: Updating documentation accordingly


Following this patches, we'll be sending the sender side of TFRC-SP.
Once this code is integrated on the branch, we can proceed adding the
CCID4 code that uses this new TFRC-SP.

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

