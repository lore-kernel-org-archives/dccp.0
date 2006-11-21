From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 21 Nov 2006 17:23:37 +0000
Subject: Re: [PATCH 0/6]: CCID 3: packet scheduling and packet size EWMA patch
Message-Id: <5640c7e00611210923paba3e08t7aedc02f82ce91cd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211544.54258@strip-the-willow>
In-Reply-To: <200611211544.54258@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Patch 4: Simplifies ccid3_hc_tx_send_packet (also reads easier afterwards)
>          --> here I have a question:
>              return type of this function is `int', if return value > 0
>              it means a delay in milliseconds. Is there any point converting
>              the function to one returning type long or is it always certain
>              that the return value is small enough that this doesn't matter?

The spec says you must send a packet at least once every 64 seconds so
it should be no higher than 64000 which is well within range of int.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
