<?php

namespace App\DataFixtures;

use App\Entity\Person;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class PersonFixture extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $person = new Person();

        $person->setName('John Doe');
        $person->setAlternateName('john');

        $manager->persist($person);

        $manager->flush();
    }
}