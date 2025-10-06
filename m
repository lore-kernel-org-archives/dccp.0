Received: from mail-pg1-f173.google.com (mail-pg1-f173.google.com [209.85.215.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0610E2DA763
	for <dccp@vger.kernel.org>; Mon,  6 Oct 2025 16:25:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1759767908; cv=none; b=T2rTxnxs5aakYRF3Xnd+jnityONHECE2nt7/T3xM1jgNP42/SSLd417Y5wS5Dcc42o6PsT8JVhUZxwcXuZw9xWeuweai21LhL7/f64+/QWI0muSHRH+KS0a7+iYaX6v0ilZcdUf9jnTiKGlcIGMErvE9B3sqZP+dwNhlBvjzZZ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1759767908; c=relaxed/simple;
	bh=wzSI+3YV5h043Yiw4KDOsFqmPFSpeSzfbDx3HQrwZTw=;
	h=Content-Type:From:To:Subject:Message-ID:Date:MIME-Version; b=XlpWmSj1yKZd8iYnrbFYrwSt9qJs7k+7vUypN/F3gJy8QdWXEppKY3jHM/dqjbfD0oTs94X1zW7KacR2SPev4DNASdHi1csEQl6vZcJ7GEXa35jImmNOU03izSxLMfZvLtaSs1v+vzlBMpwmFyvASfbMSzvRZrzw7C7TsfYyrhU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ncQS9Lom; arc=none smtp.client-ip=209.85.215.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ncQS9Lom"
Received: by mail-pg1-f173.google.com with SMTP id 41be03b00d2f7-b6093f8f71dso3344107a12.3
        for <dccp@vger.kernel.org>; Mon, 06 Oct 2025 09:25:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1759767904; x=1760372704; darn=vger.kernel.org;
        h=mime-version:date:content-transfer-encoding:message-id:subject
         :reply-to:to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=wzSI+3YV5h043Yiw4KDOsFqmPFSpeSzfbDx3HQrwZTw=;
        b=ncQS9Lom+zbzvBdl1FBNkPbgfA0W/6aegbk3UdDjuekCdbLPMlmVS/EZ1a/hnQl9t3
         rSU7RjKqbNEpyyGYcKMTo2D9Ltyc7AyvfPv/5Lp5lMM9ImouAwrId3eY15mLBj3pJqfd
         Mic4cq7gwrRiS5Bjz0MR29dNEtxCxjEdbrYHrN6EmciETBPZIawZcT6ylIrAfIYiiUhg
         4LF3oFmdKsUaW6PcyscNbjNJkmFZ/cqOBZynBPJxe2N23a3yZg/a2arjFqmQX2xZebkT
         Gy2CcnU28e9FDLMHD1h100fgMcJDALAqce+x1qz5+3OyGV5x9SEgcvMW9vNfCB6eRWiq
         5Yuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1759767904; x=1760372704;
        h=mime-version:date:content-transfer-encoding:message-id:subject
         :reply-to:to:from:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=wzSI+3YV5h043Yiw4KDOsFqmPFSpeSzfbDx3HQrwZTw=;
        b=Si9A4LIKohClurhhiJGjqgw6Gk2ZWWhMEdX8op49X1zQxGXBUxdkeTbqqimEZQsxjk
         RjUnSpIam3z34OYbPPeZ7QR1ENJf1+ROGoKObJupYrmTLz/OeQHnt2g5Gip2eojD/7DD
         fD9LwIcO+Sz5BKZZGdwE9aeHG86qwKxOGnnCA8GiGTpbvY042wkRHtFcX/PM1Z9b4KWO
         R9TqBZ2rPdn0tAc8Bm8IZRo6QQcgS3mqjA7vSL7ON8DaPm1De9VGMw85v1SC6sVNPWEF
         6W7WOxI/K0NRmo20fzJLuC+KLkPPUEGI4N3pmyJEo5puqqS7DsKOP9rxFQ15tXfNVbf8
         rw+A==
X-Gm-Message-State: AOJu0YwVZBydDtUATgzALclXWIUatC0+epJ1a3cqk40e5uMQJcHsTzPi
	fqVxD/N9G29hxnp3LS/CaV9l32eue3iynoyp9fjMAFj9CsD/nG+H7MTJirwFy7Zz
X-Gm-Gg: ASbGncsG8PBXlpMHhflSEy9frYaRONtOlQNXwMmJaRM1K5UJ+HHd96LGVGs0F6Kt1vr
	pkNcdMApOec2Uf5hmsoP5Kiohqrw2e9U8gV8pUUwSw3Z1mNShARkqrI7nORPWzloevvmlu7ZRp8
	IxlsTLCGiKNT7OQnce/fFRMxbM1j3WX8jNnuJettbmDuQTLB2FdOC+thsE2nnue32b1z7KhU8Zx
	glmB2XVl/t8KNtBTjoDO1BHbGwGQJdD2WwDmERJFSoq+81B2QFG3VibtXewt+jqZnPAQA3gvHOd
	W9nCWk8iElmuR2jiy3gidWCTSLRPES+b7CShguPB8H5101UAutHZvrzCtdWfjqIGRALCx4Mza6+
	ohG8rniiNk8LkvpzLh2nhftxMBwrePtqdcGy7VhiBWYf7064dtySLpRqjlLQFQR3Lm4aFaDi7CX
	dt9B9aL5yy5uFxZK8=
X-Google-Smtp-Source: AGHT+IGmIfbcqXfmhSM230iOsnVyYt7lQSS43xpvQwEdNujlmdLrscst8x1lld7MNhwHnJhaczGvKg==
X-Received: by 2002:a17:903:2446:b0:283:c950:a76f with SMTP id d9443c01a7336-28e9a61eda3mr139443235ad.43.1759767904064;
        Mon, 06 Oct 2025 09:25:04 -0700 (PDT)
Received: from [127.0.0.1] ([154.80.22.164])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-28e8d1ef43fsm137794075ad.122.2025.10.06.09.25.01
        for <dccp@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 06 Oct 2025 09:25:03 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
From: Bryan Kyler <bowenyu59@gmail.com>
To: dccp@vger.kernel.org
Reply-To: chrismorgance@gmail.com
Subject: Estimating & Take-Offs
Message-ID: <cab5fffc-7b7b-4ded-6cb9-1684505bdbdd@gmail.com>
Content-Transfer-Encoding: quoted-printable
Date: Mon, 06 Oct 2025 16:25:00 +0000
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hello,

We are an estimation company. We provide estimating/takeoff =
services to GC and subcontractors.

We do estimates of all types of =
construction projects.

Send me the plans for a quote if you have any job =
for us. You may ask for a sample.

Regards,
Bryan Kyler
Estimation Department
City Estimating, LLC
