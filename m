From: David Miller <davem@davemloft.net>
Date: Mon, 24 Feb 2020 21:29:34 +0000
Subject: Re: [PATCH 14/30] dccp: Add missing annotation for dccp_child_process()
Message-Id: <20200224.132934.1883265315899035765.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200223231711.157699-15-jbi.octave@gmail.com>
In-Reply-To: <20200223231711.157699-15-jbi.octave@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Jules Irenge <jbi.octave@gmail.com>
Date: Sun, 23 Feb 2020 23:16:55 +0000

> Sparse reports a warning at dccp_child_process()
> warning: context imbalance in dccp_child_process() - unexpected unlock
> The root cause is the missing annotation at dccp_child_process()
> Add the missing __releases(child) annotation
> 
> Signed-off-by: Jules Irenge <jbi.octave@gmail.com>

Applied.
