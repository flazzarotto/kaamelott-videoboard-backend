<?php

namespace App\DataFixtures;

use App\Entity\Clip;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class ClipFixture extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $clip = new Clip();

        $clip->setName('Clip 1');
        $clip->setUrl('https://example.com');

        $manager->persist($clip);

        $manager->flush();
    }
}