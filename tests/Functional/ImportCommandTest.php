<?php

/**
 * This file is part of the TangoMan package.
 *
 * Copyright (c) 2020 "Matthias Morin" <mat@tangoman.io>
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace App\Tests\Functional;

use App\Command\ImportCommand;
use App\Entity\Person;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Console\Application;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\Console\Tester\CommandTester;
use Symfony\Component\Serializer\SerializerInterface;

/**
 * Class ImportCommandTest
 * @package App\Tests\Functional
 */
class ImportCommandTest extends KernelTestCase
{
    /**
     * @var CommandTester
     */
    private $commandTester;

    /**
     * @var EntityManagerInterface
     */
    private $em;

    /**
     * @var SerializerInterface
     */
    private $serializer;

    public function testImportFromCsv(): void
    {
        $this->commandTester->execute(
            [
                '-d' => __DIR__.'/../Fixtures/',
                '-f' => 'people.csv',
            ]
        );

        $person = $this->em
            ->getRepository(Person::class)
            ->findOneBy(['alternateName' => 'damedulac']);

        $this->assertSame('La Dame du Lac', $person->getName());
    }

    protected function setup(): void
    {
        // kernel should be booted to access container
        $kernel = self::bootKernel();
        $application = new Application($kernel);

        // get entity manager
        $this->em = $kernel->getContainer()->get('doctrine')->getManager();

        // get serializer
        $this->serializer = $kernel->getContainer()->get('serializer');

        // init command
        $application->add(
            new ImportCommand(
                $this->em,
                $this->serializer
            )
        );

        $command = $application->find('app:import');
        $this->commandTester = new CommandTester($command);
    }

    protected function tearDown(): void
    {
        parent::tearDown();

        // doing this is recommended to avoid memory leaks
        $this->em->close();
        $this->em = null;

        $this->commandTester = null;
        $this->serializer = null;
    }
}