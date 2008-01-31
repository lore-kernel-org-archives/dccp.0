From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 31 Jan 2008 17:10:40 +0000
Subject: Re: CCID3 over WiFi Study
Message-Id: <5640c7e00801310910o2efddd6coe0217d9f3187b2f6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20080131134138.GA13260@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080131134138.GA13260@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Feb 1, 2008 2:41 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have uploaded an annotated set of plots on CCID3 over WiFi on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/ccid3_over_wifi/
>
> The interest was to get away from emulated networks. The WiFi link provides
> a real-world scenario which will create loss (100Mbs feeding into 11Mbps).
>
> Note: While doing these tests several more bugs in iperf (DCCP mode) were
>       found (and fixed). The improved variant will be uploaded soon.
>
> Gerrit

Gerrit - nice work. Very thorough.

Interesting implications for use of media on the Internet....

The killer is the large buffering - do you know what size the Linksys
has? Also what size transmit buffer and what size sequence validation
window did you use. If these two were reduced then you might stop the
buffering occurring elsewhere...

Regards

Ian

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
