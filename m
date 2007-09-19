From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 20:08:45 +0000
Subject: Re: mss in CCID 4 draft
Message-Id: <5bc4c4570709191308j73013991q3c84f4a45d24acad@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070919162029.GA8457@kikai.katei.fi>
In-Reply-To: <20070919162029.GA8457@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Tommi,
  I think that this apply to tfrc_calc_x. If I understood well your
question, if you verify the TFRC equation (RFC 3448), section 3.1 you
can see the parameters that are included in TCP throughput equation.
Futhermore, the section 5 (Loss Event Rate) mention that loss event
rate, a rrt estimation and a nominal packet size (1460 bytes) are
plugged into the TCP throughput, as specified in RFC 3448 and RFC
4828.

Leandro.

2007/9/19, Tommi Saviranta <wnd@iki.fi>:
> Since English isn't my native language, and because I have a habit of
> making small uncertainties into big problems, I'd like to hear your
> interpretation on this.
>
> Introduction, the nominal segment size: "In TFRC-SP, the nominal segment
> size used by the TCP throughput equation is set to 1460 bytes." What
> kind of things are included in "TCP throughput equation"? Does this
> apply to tfrc_calc_x() in ccid3_hc_tx_packet_recv(), and to scaled_div()
> in ccid4_first_li()?
>
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
