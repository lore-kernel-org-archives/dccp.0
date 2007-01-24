From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Jan 2007 08:26:54 +0000
Subject: Re: [PATCH 6/7]: Sample RTT from SYN exchange
Message-Id: <200701240826.55063@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701231541.11648@strip-the-willow>
In-Reply-To: <200701231541.11648@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Doesn't this rely on the receiver sending back the RTT which
|  it can't know at that point of time?? It's only had the request then
|  so rtt can only be determined by the receiver. But I could be wrong
|  here and I will go back and read the code/rfcs when back at home.
It samples the RTT from the initial SYN (Request/Response) exchange:
 * the client adds a timestamp option when sending its Request
 * it then enters the REQUEST state and waits for the matching Response
 * when the server replies with a timestamp echo option, the client
   subtracts this value from t_now, and also the elapsed_time (if supplied)
 * if there is no timestamp echo option in the reply, it does not set the field
Using the SYN exchange is suggested both in the erratum to RFC 4342 and in
draft 3448bis.

- Gerrit
