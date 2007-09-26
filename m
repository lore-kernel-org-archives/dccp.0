From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 26 Sep 2007 13:19:48 +0000
Subject: Header size of the data packet
Message-Id: <5bc4c4570709260619w27b29866l59bbff6747105a97@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

   according to ccid-4 internet draft, "the estimated header size on
data packets is 36 bytes (20 bytes for the IP header and 16 bytes for
the DCCP-data header with 48-bit sequence numbers). The header size
would be 32 bytes instead of 36 bytes when 24-bit sequence number were
used in the DCCP-data header."
   In this case, how can I get this information if dccp will use
48-bit or 24-bit sequence number?

Leandro.
