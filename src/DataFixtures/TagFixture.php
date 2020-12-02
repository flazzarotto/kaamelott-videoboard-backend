<?php

namespace App\DataFixtures;

use App\Entity\Tag;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class TagFixture extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $tag = new Tag();

        $tag->setName('tag_1');

        $manager->persist($tag);

        $manager->flush();
    }
}