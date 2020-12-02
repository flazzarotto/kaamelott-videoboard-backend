<?php

namespace App\DataFixtures;

use App\Entity\Episode;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class EpisodeFixture extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $episode = new Episode();

        $episode->setName('Episode 1');

        $manager->persist($episode);

        $manager->flush();
    }
}