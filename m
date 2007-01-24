From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 24 Jan 2007 01:27:55 +0000
Subject: Re: [PATCH 4/7]: Provide function for RTT sampling
Message-Id: <5640c7e00701231727y58907539xb2531641fece4c13@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231541.01730@strip-the-willow>
In-Reply-To: <200701231541.01730@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Is 100 microseconds a bit high perhaps? I'm seeing about 250
microseconds on a 100 Mbits LAN and therefore presumably on a 10 Gbits
LAN it could be as low as 2.5 microseconds??

Other than that:
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>


On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Provide function for RTT sampling
>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
