From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 20:31:57 +0000
Subject: CCID 3 and CCID 4 to streaming adaptation
Message-Id: <5bc4c4570709191331y5696a14o96e35b5d6124b641@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

   it RFC 4342, section 5.3 (Packet Sizes), it says that CCID-3 is not
appropriate for applications that require a fixed interval of time
between packets and vary their packet size instead of their packet
rate in response to congestion. The question is: in this case it is
not recommended to use VBR codecs such as SPEEX on the application
layer? Is this same issue occurs in the CCID-4?

Leandro.

-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
