From: Leandro Sales <leandroal@gmail.com>
Date: Wed, 28 Jan 2009 20:13:14 +0000
Subject: Get Current CCID
Message-Id: <5bc4c4570901281213h48465d52s3c97039af39bc70@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,
   consider this:
     getsockopt (so, SOL_DCCP, DCCP_SOCKOPT_RX_CCID, &ccid, &ccidlen);

   Is there any reason for getsockopt is returning 255? This is
happening with me using 2.6.29-rc2 (your test tree)

Thank you,
Leandro.
