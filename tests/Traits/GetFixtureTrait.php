<?php

/**
 * This file is part of the TangoMan package.
 *
 * Copyright (c) 2020 "Matthias Morin" <mat@tangoman.io>
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace App\Tests\Traits;

trait GetFixtureTrait
{
    /**
     * @param string $filename
     *
     * @return array
     */
    public function getFixtureFromJsonFile($filename)
    {
        return json_decode(file_get_contents(__DIR__.'/../Fixtures/'.$filename), true);
    }
}

